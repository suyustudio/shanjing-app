.class public final Ls0/g$a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ls0/g;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "a"
.end annotation


# direct methods
.method public static a(Ls0/g;Ls0/g;)Ls0/g;
    .locals 1

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    sget-object v0, Ls0/h;->d:Ls0/h;

    if-ne p1, v0, :cond_0

    goto :goto_0

    :cond_0
    sget-object v0, Ls0/g$a$a;->d:Ls0/g$a$a;

    invoke-interface {p1, p0, v0}, Ls0/g;->fold(Ljava/lang/Object;La1/p;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ls0/g;

    :goto_0
    return-object p0
.end method
