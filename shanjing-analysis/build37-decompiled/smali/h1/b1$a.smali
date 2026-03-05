.class public final Lh1/b1$a;
.super Ls0/b;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lh1/b1;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ls0/b<",
        "Lh1/f0;",
        "Lh1/b1;",
        ">;"
    }
.end annotation


# direct methods
.method private constructor <init>()V
    .locals 2

    sget-object v0, Lh1/f0;->d:Lh1/f0$a;

    sget-object v1, Lh1/b1$a$a;->d:Lh1/b1$a$a;

    invoke-direct {p0, v0, v1}, Ls0/b;-><init>(Ls0/g$c;La1/l;)V

    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/internal/e;)V
    .locals 0

    invoke-direct {p0}, Lh1/b1$a;-><init>()V

    return-void
.end method
