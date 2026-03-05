.class final Lg1/n$b;
.super Lkotlin/jvm/internal/j;
.source "SourceFile"

# interfaces
.implements La1/l;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lg1/n;->N(Ljava/lang/CharSequence;[Ljava/lang/String;ZI)Lf1/b;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Lkotlin/jvm/internal/j;",
        "La1/l<",
        "Ld1/c;",
        "Ljava/lang/String;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic d:Ljava/lang/CharSequence;


# direct methods
.method constructor <init>(Ljava/lang/CharSequence;)V
    .locals 0

    iput-object p1, p0, Lg1/n$b;->d:Ljava/lang/CharSequence;

    const/4 p1, 0x1

    invoke-direct {p0, p1}, Lkotlin/jvm/internal/j;-><init>(I)V

    return-void
.end method


# virtual methods
.method public final a(Ld1/c;)Ljava/lang/String;
    .locals 1

    const-string v0, "it"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v0, p0, Lg1/n$b;->d:Ljava/lang/CharSequence;

    invoke-static {v0, p1}, Lg1/n;->P(Ljava/lang/CharSequence;Ld1/c;)Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method

.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ld1/c;

    invoke-virtual {p0, p1}, Lg1/n$b;->a(Ld1/c;)Ljava/lang/String;

    move-result-object p1

    return-object p1
.end method
