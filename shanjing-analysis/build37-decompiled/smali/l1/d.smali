.class public final Ll1/d;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field private static final a:La1/q;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/q<",
            "Lk1/c<",
            "Ljava/lang/Object;",
            ">;",
            "Ljava/lang/Object;",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    sget-object v0, Ll1/d$a;->d:Ll1/d$a;

    const/4 v1, 0x3

    invoke-static {v0, v1}, Lkotlin/jvm/internal/n;->a(Ljava/lang/Object;I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, La1/q;

    sput-object v0, Ll1/d;->a:La1/q;

    return-void
.end method

.method public static final synthetic a()La1/q;
    .locals 1

    sget-object v0, Ll1/d;->a:La1/q;

    return-object v0
.end method
