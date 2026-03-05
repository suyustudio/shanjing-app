.class public abstract Lh1/b1;
.super Lh1/f0;
.source "SourceFile"

# interfaces
.implements Ljava/io/Closeable;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lh1/b1$a;
    }
.end annotation


# static fields
.field public static final e:Lh1/b1$a;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lh1/b1$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lh1/b1$a;-><init>(Lkotlin/jvm/internal/e;)V

    sput-object v0, Lh1/b1;->e:Lh1/b1$a;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lh1/f0;-><init>()V

    return-void
.end method
